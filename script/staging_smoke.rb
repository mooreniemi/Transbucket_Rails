#!/usr/bin/env ruby

require "net/http"
require "nokogiri"
require "securerandom"
require "uri"

# This smoke works against either staging or localhost.
# For localhost, the test DB needs the seeded `zoon` admin from
# `db/seeds/test_users.rb`, Elasticsearch must be reachable, and a
# delayed_job worker must be running so pin indexing jobs get processed.
STAGING_URL = ENV.fetch("STAGING_URL", "https://transbucket-staging.herokuapp.com")
STAGING_LOCALES = ENV.fetch("STAGING_LOCALES", ENV.fetch("STAGING_LOCALE", "en")).split(",").map(&:strip).reject(&:empty?)
USERNAME = ENV.fetch("STAGING_USER", "zoon")
PASSWORD = ENV.fetch("STAGING_PASSWORD")
IMAGE_PATH = File.expand_path("../spec/fixtures/cat.jpg", __dir__)
NEWSFEED_TITLES = {
  "en" => "Newsfeed",
  "de" => "Neuigkeiten",
  "es" => "Novedades",
  "fr" => "Actualités",
  "it" => "Novità",
  "ja" => "ニュース",
  "zh-CN" => "新闻",
  "zh-TW" => "最新消息",
  "pt-BR" => "Novidades",
  "nl" => "Nieuws",
  "pl" => "Aktualności",
  "ru" => "Новости",
  "tr" => "Haberler",
  "vi" => "Tin tức",
  "ar" => "الأخبار"
}.freeze
REGISTRATION_MARKERS = {
  "en" => "Username", "de" => "Benutzername", "es" => "Nombre de usuario",
  "fr" => "Nom d’utilisateur", "it" => "Nome utente", "ja" => "ユーザー名",
  "zh-CN" => "用户名", "zh-TW" => "使用者名稱", "pt-BR" => "Nome de usuário",
  "nl" => "Gebruikersnaam", "pl" => "Nazwa użytkownika", "ru" => "Имя пользователя",
  "tr" => "Kullanıcı adı", "vi" => "Tên người dùng", "ar" => "اسم المستخدم"
}.freeze
ACCOUNT_MARKERS = {
  "en" => ["Name", "Safe mode"],
  "de" => ["Name", "Sicherer Modus"],
  "es" => ["Nombre", "Modo seguro"],
  "fr" => ["Nom", "Mode sécurisé"],
  "it" => ["Nome", "Modalità sicura"],
  "ja" => ["名前", "セーフモード"],
  "zh-CN" => ["姓名", "安全模式"],
  "zh-TW" => ["姓名", "安全模式"],
  "pt-BR" => ["Nome", "Modo seguro"],
  "nl" => ["Naam", "Veilige modus"],
  "pl" => ["Imię", "Tryb bezpieczny"],
  "ru" => ["Имя", "Безопасный режим"],
  "tr" => ["Ad", "Güvenli mod"],
  "vi" => ["Tên", "Chế độ an toàn"],
  "ar" => ["الاسم", "الوضع الآمن"]
}.freeze

class StagingSmoke
  def initialize(locale)
    @locale = locale
    @cookies = {}
  end

  def run
    verify_public_localization
    verify_registration_localization
    login
    verify_account_localization
    pin_id, search_term = create_pin
    edit_pin(pin_id)
    verify_search_page
    verify_search_results(search_term, pin_id)
    puts "staging smoke ok locale=#{@locale} pin=#{pin_id}"
  end

  private

  def verify_public_localization
    legacy = get_legacy("/")
    unless legacy.code.to_i == 301 && URI.parse(legacy["location"]).path == "/en/"
      raise "legacy homepage did not redirect to /en/"
    end

    localized = get("/")
    expected_title = NEWSFEED_TITLES.fetch(@locale)
    unless localized.code.to_i == 200 && localized.body.include?(%(<html lang="#{@locale}">)) && localized.body.include?('hreflang="x-default"')
      raise "localized homepage metadata failed"
    end

    newsfeed = get("/newsfeed")
    unless newsfeed.code.to_i == 200 && newsfeed.body.include?(expected_title)
      raise "localized newsfeed failed"
    end
  end

  def verify_registration_localization
    response = get("/register")
    marker = REGISTRATION_MARKERS.fetch(@locale)
    unless response.code.to_i == 200 && response.body.include?(marker)
      raise "localized registration form failed for #{@locale}"
    end
  end

  def login
    token = csrf_token("/users/sign_in")
    params = {
      "user[login]" => USERNAME,
      "user[password]" => PASSWORD,
      "commit" => "Sign in"
    }
    params["authenticity_token"] = token if token
    response = post("/users/sign_in", params)

    unless response.code.to_i.between?(200, 399)
      raise "login failed with #{response.code}"
    end

    follow_redirect(response) if response.is_a?(Net::HTTPRedirection)
    auth_check = get("/pins/new")

    unless auth_check.code.to_i == 200
      raise "login did not establish an authenticated session"
    end
  end

  def verify_account_localization
    response = get("/users/edit")
    profile_label, settings_label = ACCOUNT_MARKERS.fetch(@locale)
    unless response.code.to_i == 200 && response.body.include?(profile_label) && response.body.include?(settings_label)
      raise "localized account page failed for #{@locale}"
    end
  end

  def create_pin
    token = csrf_token("/pins/new")
    suffix = Time.now.to_i
    captions = ["Smoke test image 1", "Smoke test image 2"]

    params = {
      "pin[cost]" => "123",
      "pin[sensation]" => "4",
      "pin[satisfaction]" => "5",
      "pin[details]" => "Smoke test details",
      "pin[surgeon_attributes][last_name]" => "Smoke#{suffix}",
      "pin[surgeon_attributes][first_name]" => "User",
      "pin[surgeon_attributes][url]" => "https://example.com/surgeons/#{suffix}",
      "pin[procedure_attributes][name]" => "Smoke Procedure #{suffix}",
      "pin[procedure_attributes][body_type]" => "Top",
      "pin[procedure_attributes][gender]" => "FTM",
      "pin_images[0][caption]" => captions[0],
      "pin_images[0][photo]" => multipart_upload,
      "pin_images[1][caption]" => captions[1],
      "pin_images[1][photo]" => multipart_upload
    }
    params["authenticity_token"] = token if token

    response = post_multipart("/pins", params)

    location = response["location"]
    unless response.code.to_i == 302 && location
      raise "pin create failed with #{response.code}"
    end

    pin_id = location[%r{/pins/(\d+)}, 1] || raise("could not parse created pin id")
    show = get("/pins/#{pin_id}").body

    unless show.include?(captions[0]) && show.include?(captions[1]) && show.include?(localized_pin_label)
      raise "multi-image upload did not persist both captions"
    end

    [pin_id, params["pin[procedure_attributes][name]"]]
  end

  def localized_pin_label
    {
      "en" => "Surgeon",
      "de" => "Chirurg",
      "es" => "Cirujano",
      "fr" => "Chirurgien",
      "it" => "Chirurgo",
      "ja" => "外科医",
      "zh-CN" => "医生",
      "zh-TW" => "醫師",
      "pt-BR" => "Cirurgião",
      "nl" => "Chirurg",
      "pl" => "Chirurg",
      "ru" => "Хирург",
      "tr" => "Cerrah",
      "vi" => "Bác sĩ phẫu thuật",
      "ar" => "الجراح"
    }.fetch(@locale)
  end

  def edit_pin(pin_id)
    edit_path = "/pins/#{pin_id}/edit"
    doc = html_document(get(edit_path).body)
    token = csrf_token(edit_path, doc)

    surgeon_id = selected_value(doc, "select#pin_surgeon_attributes_id")
    procedure_id = selected_value(doc, "select#pin_procedure_attributes_id")

    response = post(
      "/pins/#{pin_id}",
      {
        "_method" => "patch",
        "pin[cost]" => "456",
        "pin[details]" => "Smoke test details updated",
        "pin[surgeon_attributes][id]" => surgeon_id,
        "pin[procedure_attributes][id]" => procedure_id
      }.tap { |params| params["authenticity_token"] = token if token },
      method: :post
    )

    unless response.code.to_i == 302
      raise "pin edit failed with #{response.code}"
    end

    show = get("/pins/#{pin_id}").body

    unless show.include?("456") && show.include?("Smoke test details updated")
      raise "updated pin data missing"
    end
  end

  def verify_search_page
    response = get("/pins?query=does-not-exist-#{Time.now.to_i}")
    unless response.code.to_i == 200
      raise "search page failed with #{response.code}"
    end
  end

  def verify_search_results(search_term, pin_id)
    # A 200 alone is not enough here; recent-fallback also returns 200.
    # We wait until the created pin is the only result card on the page.
    deadline = Time.now + 30
    search_url = "/pins?query=#{URI.encode_www_form_component(search_term)}"

    loop do
      response = get(search_url)
      unless response.code.to_i == 200
        raise "search results failed with #{response.code}"
      end

      pins = response.body.scan(/data-pin-id="(\d+)"/).flatten
      if pins == [pin_id.to_s]
        return
      end

      break if Time.now >= deadline
      sleep 2
    end

    raise "created pin #{pin_id} did not become searchable for #{search_term}"
  end

  def csrf_token(path, doc = nil)
    doc ||= html_document(get(path).body)
    node = doc.at_css("meta[name='csrf-token']") || doc.at_css("input[name='authenticity_token']")
    node && (node["content"] || node["value"])
  end

  def selected_value(doc, selector)
    node = doc.at_css("#{selector} option[selected]")
    node && node["value"] || raise("selected value missing for #{selector}")
  end

  def multipart_upload
    {
      filename: File.basename(IMAGE_PATH),
      content_type: "image/jpeg",
      body: File.binread(IMAGE_PATH)
    }
  end

  def html_document(body)
    Nokogiri::HTML(body)
  end

  def follow_redirect(response)
    location = response["location"]
    get(location) if location
  end

  def get(path)
    target = uri(path)
    request(target, Net::HTTP::Get.new(target))
  end

  def get_legacy(path)
    target = URI.join(STAGING_URL, path)
    request(target, Net::HTTP::Get.new(target))
  end

  def post(path, params, method: :post)
    target = uri(path)
    req = case method
    when :post
      Net::HTTP::Post.new(target)
    when :patch
      Net::HTTP::Patch.new(target)
    else
      raise ArgumentError, "unsupported method #{method}"
    end

    req.set_form_data(params)
    request(target, req)
  end

  def post_multipart(path, params)
    target = uri(path)
    boundary = "----TransbucketSmoke#{SecureRandom.hex(8)}"
    req = Net::HTTP::Post.new(target)
    req["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
    req.body = build_multipart_body(params, boundary)
    request(target, req)
  end

  def build_multipart_body(params, boundary)
    chunks = params.map do |key, value|
      if value.is_a?(Hash) && value[:body]
        [
          "--#{boundary}",
          %(Content-Disposition: form-data; name="#{key}"; filename="#{value[:filename]}"),
          "Content-Type: #{value[:content_type]}",
          "",
          value[:body]
        ].join("\r\n")
      else
        [
          "--#{boundary}",
          %(Content-Disposition: form-data; name="#{key}"),
          "",
          value.to_s
        ].join("\r\n")
      end
    end

    chunks << "--#{boundary}--"
    chunks.join("\r\n")
  end

  def request(target, req)
    req["Cookie"] = cookie_header unless @cookies.empty?
    req["User-Agent"] = "Transbucket staging smoke"

    response = Net::HTTP.start(target.host, target.port, use_ssl: target.scheme == "https") do |http|
      http.request(req)
    end

    response.body.force_encoding(Encoding::UTF_8)
    store_cookies(response)
    response
  end

  def uri(path)
    target = URI.join(STAGING_URL, path)
    return target unless target.host == URI.parse(STAGING_URL).host
    return target if target.path.match?(%r{\A/(en|de|es|fr|it|ja|zh-CN|zh-TW|pt-BR|nl|pl|ru|tr|vi|ar)(/|$)})

    target.path = "/#{@locale}#{target.path}"
    target
  end

  def store_cookies(response)
    Array(response.get_fields("set-cookie")).each do |cookie|
      key, value = cookie.split(";", 2).first.split("=", 2)
      @cookies[key] = value
    end
  end

  def cookie_header
    @cookies.map { |key, value| "#{key}=#{value}" }.join("; ")
  end
end

STAGING_LOCALES.each { |locale| StagingSmoke.new(locale).run }
