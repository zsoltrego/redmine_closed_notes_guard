# frozen_string_literal: true

module RedmineClosedNotesGuard
  module Patches
    module JournalsControllerPatch
      def self.included(base)
        base.class_eval do
          alias_method :update_without_rcng, :update
          alias_method :update, :update_with_rcng
        end
      end

      def update_with_rcng
        journal = Journal.find(params[:id])
        issue = journal.journalized.is_a?(Issue) ? journal.journalized : nil

        if issue&.closed? && params.dig(:journal, :notes).present?
          plugin_settings = Setting.plugin_redmine_closed_notes_guard || {}
          blocked_ids = Array(plugin_settings['blocked_role_ids']).reject(&:blank?).map(&:to_i)
          user_role_ids = User.current.roles_for_project(issue.project).map(&:id)

          if blocked_ids.any? && (user_role_ids & blocked_ids).any?
            render plain: l(:rcng_error_closed_issue_notes_forbidden), status: 403
            return
          end
        end

        update_without_rcng
      end
    end
  end
end

# JournalsController may not be loaded in some setups until needed
if defined?(JournalsController) && !JournalsController.included_modules.include?(RedmineClosedNotesGuard::Patches::JournalsControllerPatch)
  JournalsController.include RedmineClosedNotesGuard::Patches::JournalsControllerPatch
end
