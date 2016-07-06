require "rails_helper"

# rubocop:disable Metrics/LineLength
RSpec.describe GitHub::EventMessages::DeploymentStatus, type: :model do
  let(:org) { team.organizations.create(name: "heroku", webhook_id: 42) }
  let(:team) { SlackHQ::Team.from_omniauth(slack_omniauth_hash_for_atmos) }

  it "returns a started message the state is pending" do
    data = fixture_data("webhooks/deployment_status-pending")

    handler = GitHub::EventMessages::DeploymentStatus.new(team, org, data)
    response = handler.response
    expect(response).to_not be_nil
    expect(response[:channel]).to eql("#general")
    attachments = response[:attachments]
    expect(attachments.first[:color]).to eql("#c0c0c0")
    expect(attachments.first[:text])
      .to eql("<https://github.com/atmos|atmos> is deploying <https://github.com/atmos-org/speakerboxxx/tree/923821e5|speakerboxxx/master> to <https://dashboard.heroku.com/apps/speakerboxxx-production/activity/builds/96d42bc6-4461-49d2-be08-0208531728c4|production>.")
    expect(attachments.first[:fallback])
      .to eql("atmos is deploying speakerboxxx/master to production.")
  end

  it "returns a Slack message if the state is success" do
    data = fixture_data("webhooks/deployment_status-success")

    handler = GitHub::EventMessages::DeploymentStatus.new(team, org, data)
    response = handler.response
    expect(response).to_not be_nil
    expect(response[:channel]).to eql("#general")
    attachments = response[:attachments]
    expect(attachments.first[:color]).to eql("#36a64f")
    expect(attachments.first[:text])
      .to eql("<https://github.com/atmos|atmos>'s <https://dashboard.heroku.com/apps/speakerboxxx-production/activity/builds/96d42bc6-4461-49d2-be08-0208531728c4|production> deployment of <https://github.com/atmos-org/speakerboxxx/tree/923821e5|speakerboxxx/master> was successful. 31s")
    expect(attachments.first[:fallback])
      .to eql("atmos's production deployment of speakerboxxx/master was successful. 31s")
  end

  it "returns a Slack message if the status is failure" do
    data = fixture_data("webhooks/deployment_status-failure")

    handler = GitHub::EventMessages::DeploymentStatus.new(team, org, data)
    response = handler.response
    expect(response).to_not be_nil
    expect(response[:channel]).to eql("#general")
    attachments = response[:attachments]
    expect(attachments.first[:color]).to eql("#f00")
    expect(attachments.first[:text])
      .to eql("<https://github.com/atmos|atmos>'s <https://dashboard.heroku.com/apps/speakerboxxx-production/activity/builds/96d42bc6-4461-49d2-be08-0208531728c4|production> deployment of <https://github.com/atmos-org/speakerboxxx/tree/923821e5|speakerboxxx/master> failed. 31s")
    expect(attachments.first[:fallback])
      .to eql("atmos's production deployment of speakerboxxx/master failed. 31s")
  end

  it "returns a Slack message if they deployed ref is a full sha" do
    data = fixture_data("webhooks/deployment_status-full-ref")

    handler = GitHub::EventMessages::DeploymentStatus.new(team, org, data)
    response = handler.response
    expect(response).to_not be_nil
    expect(response[:channel]).to eql("#general")
    attachments = response[:attachments]
    expect(attachments.first[:color]).to eql("#f00")
    expect(attachments.first[:text])
      .to eql("<https://github.com/atmos|atmos>'s <https://dashboard.heroku.com/apps/speakerboxxx-production/activity/builds/96d42bc6-4461-49d2-be08-0208531728c4|production> deployment of <https://github.com/atmos-org/speakerboxxx/tree/923821e5|speakerboxxx/923821e5> failed. 31s")
    expect(attachments.first[:fallback])
      .to eql("atmos's production deployment of speakerboxxx/923821e5 failed. 31s")
  end
end
# rubocop:enable Metrics/LineLength