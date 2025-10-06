# app/jobs/party/suggestions/discover_job.rb
class Party::Suggestions::DiscoverJob < ApplicationJob
  queue_as :default

  def perform
    link_results  = Party::Suggestions::LinkRules.run(limit: 10_000)
    group_results = Party::Suggestions::GroupRules.run(limit: 1_000)
    Party::Suggestions::Persist.links!(link_results)
    Party::Suggestions::Persist.groups!(group_results)
  end
end
