#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

# FIXME: on upgrade
# https://stackoverflow.com/questions/35893584/nomethoderror-undefined-method-last-comment-after-upgrading-to-rake-11
module TempFixForRakeLastComment
  def last_comment
    last_description
  end
end
Rake::Application.send :include, TempFixForRakeLastComment

Transbucket::Application.load_tasks
