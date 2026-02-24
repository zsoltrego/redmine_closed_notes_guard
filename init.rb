# frozen_string_literal: true

Redmine::Plugin.register :closed_notes_guard do
  name 'Closed Notes Guard plugin'
  author 'ZsoltRego'
  description 'Block adding/editing notes on closed issues for selected roles.'
  version '1.0.1'
  url 'https://github.com/zsoltrego/closed_notes_guard'
  requires_redmine version_or_higher: '6.1.0'

  settings default: { 'blocked_role_ids' => [] },
           partial: 'settings/closed_notes_guard_settings'
end

Rails.configuration.to_prepare do
  require_dependency 'closed_notes_guard/patches/issues_controller_patch'
  require_dependency 'closed_notes_guard/patches/journals_controller_patch'
  require_dependency 'closed_notes_guard/patches/journal_model_patch'
end
