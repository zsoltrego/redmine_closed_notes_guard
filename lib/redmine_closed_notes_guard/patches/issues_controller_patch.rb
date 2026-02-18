# frozen_string_literal: true

module RedmineClosedNotesGuard
  module Patches
    module IssuesControllerPatch
      def self.included(base)
        base.class_eval do
          alias_method :update_without_rcng, :update
          alias_method :update, :update_with_rcng
        end
      end

      def update_with_rcng
        issue = Issue.find(params[:id])

        if issue.closed? && params.dig(:issue, :notes).present?
          blocked_ids = Array(Setting.plugin_redmine_closed_notes_guard['blocked_role_ids']).map(&:to_i)
          user_role_ids = User.current.roles_for_project(issue.project).map(&:id)

          if blocked_ids.any? && (user_role_ids & blocked_ids).any?
            flash[:error] = l(:rcng_error_closed_issue_notes_forbidden)
            @issue = issue
            return render :edit, status: 403
          end
        end

        update_without_rcng
      end
    end
  end
end

unless IssuesController.included_modules.include?(RedmineClosedNotesGuard::Patches::IssuesControllerPatch)
  IssuesController.include RedmineClosedNotesGuard::Patches::IssuesControllerPatch
end
