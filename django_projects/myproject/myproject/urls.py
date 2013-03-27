#basis for this was cms url configuration

from django.conf.urls.defaults import *
from django.contrib import admin
from django.conf import settings
from django.conf.urls.static import static

admin.autodiscover()

urlpatterns = patterns('',
    (r'^admin/', include(admin.site.urls)),
    url(r'^', include('cms.urls')),
    (r'^accounts/', include('registration.backends.default.urls')),
    (r'^photologue/', include('photologue.urls')),
	(r'^gallery/', include('photologue.urls')),
	)

if settings.DEBUG:
    urlpatterns = patterns('',
    url(r'^media/(?P<path>.*)$', 'django.views.static.serve',
        {'document_root': settings.MEDIA_ROOT, 'show_indexes': True}),
    url(r'', include('django.contrib.staticfiles.urls')),
) + urlpatterns