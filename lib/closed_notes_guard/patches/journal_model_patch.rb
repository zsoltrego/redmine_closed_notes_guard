# frozen_string_literal: true

module RedmineClosedNotesGuard
  module Patches
    module JournalModelPatch
      def self.included(base)
        base.class_eval do
          validate :rcng_block_notes_on_closed_issue_for_roles
        end
      end

      private

      def rcng_block_notes_on_closed_issue_for_roles
        # Only care about journals on issues
        issue = journalized.is_a?(Issue) ? journalized : nil
        return unless issue

        # Only when issue is closed
        return unless issue.closed?

        # Only when notes are present (adding/editing a comment)
        return unless notes.present?

        plugin_settings = Setting.plugin_redmine_closed_notes_guard || {}
        blocked_ids = Array(plugin_settings['blocked_role_ids']).reject(&:blank?).map(&:to_i)
        return if blocked_ids.empty?

        user = User.current
        return if user.nil? || user.anonymous?

        user_role_ids = user.roles_for_project(issue.project).map(&:id)

        # If user has any blocked role -> forbid
        return if (user_role_ids & blocked_ids).empty?

        errors.add(:notes, :rcng_notes_forbidden_on_closed)
      end
    end
  end
end

unless Journal.included_modules.include?(RedmineClosedNotesGuard::Patches::JournalModelPatch)
  Journal.include RedmineClosedNotesGuard::Patches::JournalModelPatch
end
