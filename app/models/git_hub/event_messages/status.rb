module GitHub::EventMessages
  # Class to generate Slack Messages based on a GitHub Status Webhook
  class Status
    attr_accessor :body, :org, :team
    def initialize(team, org, body)
      @org  = org
      @team = team
      @body = JSON.parse(body)
    end

    def repo_name
      body["repository"]["name"]
    end

    def full_name
      body["repository"]["full_name"]
    end

    def branch
      @branch ||= branch!
    end

    def branch!
      if body["branches"].any?
        body["branches"].first["name"]
      else
        short_sha
      end
    end

    def branch_ref
      if short_sha == branch
        short_sha
      else
        "#{branch}@#{short_sha}"
      end
    end

    def target_url
      body["target_url"]
    end

    def repo_url
      "https://github.com/#{full_name}"
    end

    def branch_url
      "#{repo_url}/tree/#{branch}"
    end

    def sha_url
      "#{repo_url}/tree/#{short_sha}"
    end

    def title
      "<#{branch_url}|[#{repo_name}:#{branch}]>"
    end

    def short_sha
      body["sha"][0..7]
    end

    def actor
      commit["committer"]["login"]
    end

    def commit
      body["commit"]
    end

    def state_description
      case body["state"]
      when "success"
        "was successful"
      else
        "failed"
      end
    end

    def message_color
      body["state"] == "success" ? "#36a64f" : "#f00"
    end

    def actor_description
      case actor
      when "web-flow"
        ""
      else
        " on behalf of #{actor}"
      end
    end

    def footer_text
      case body["context"]
      when "ci/circleci"
        "circle-ci#{actor_description}"
      when "continuous-integration/travis-ci/push"
        "Travis-CI#{actor_description}"
      when "heroku/compliance"
        "Changeling: #{body['description']}"
      else
        "Unknown"
      end
    end

    def footer_icon
      case body["context"]
      when "ci/circleci"
        "https://cloud.githubusercontent.com/assets/38/16295346/2b121e26-38db-11e6-9c4f-ee905519fdf3.png" # rubocop:disable Metrics/LineLength
      when "continuous-integration/travis-ci/push"
        "https://cdn.travis-ci.com/images/logos/TravisCI-Mascot-grey-ab1429c891b31bb91d29cc0b5a9758de.png" # rubocop:disable Metrics/LineLength
      when "heroku/compliance"
        "https://cloud.githubusercontent.com/assets/38/16531791/ebc00ff4-3f82-11e6-919b-693a5cf9183a.png" # rubocop:disable Metrics/LineLength
      when "vulnerabilities/gems"
        "https://cloud.githubusercontent.com/assets/38/16547100/e23b670e-4116-11e6-8b38-bac1b4c853f0.jpg" # rubocop:disable Metrics/LineLength
      end
    end

    def suppressed_contexts
      %w{codeclimate continuous-integration/travis-ci/pr vulnerabilities/gems}
    end

    # rubocop:disable Metrics/AbcSize
    def response
      return if body["state"] == "pending"
      return if suppressed_contexts.include?(body["context"])
      {
        channel: org.default_room_for(repo_name),
        attachments: [
          {
            fallback: "#{full_name} build of #{branch} was #{state_description}", # rubocop:disable Metrics/LineLength
            color: message_color,
            text: "<#{repo_url}|#{full_name}> build of <#{branch_url}|#{branch_ref}> #{state_description}. <#{target_url}|Details>", # rubocop:disable Metrics/LineLength
            footer: footer_text,
            footer_icon: footer_icon,
            mrkdwn_in: [:text, :pretext]
          }
        ]
      }
    end
    # rubocop:enable Metrics/AbcSize
  end
end