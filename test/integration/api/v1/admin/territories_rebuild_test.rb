require "test_helper"
require "active_job/test_helper"

class Api::V1::Admin::TerritoriesRebuildTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "enqueues rebuild when admin token is valid" do
    with_admin_token("secret-token") do
      assert_enqueued_with(job: RebuildTerritoriesJob, args: [nil]) do
        post "/api/v1/admin/territories/rebuild",
             headers: { "X-Admin-Token" => "secret-token" },
             as: :json
      end

      assert_response :accepted
    end
  end

  test "rejects invalid admin token" do
    with_admin_token("secret-token") do
      post "/api/v1/admin/territories/rebuild",
           headers: { "X-Admin-Token" => "wrong-token" },
           as: :json

      assert_response :unauthorized
    end
  end

  private

  def with_admin_token(token)
    previous = ENV["CONQURUN_ADMIN_TOKEN"]
    ENV["CONQURUN_ADMIN_TOKEN"] = token
    yield
  ensure
    ENV["CONQURUN_ADMIN_TOKEN"] = previous
  end
end
