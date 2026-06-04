require "test_helper"

class ApiDocsTest < ActionDispatch::IntegrationTest
  test "serves raw openapi yaml" do
    get "/api-docs/openapi.yaml"

    assert_response :success
    assert_includes response.media_type, "yaml"
    assert_includes response.body, "openapi: 3.1.0"
  end

  test "redirects docs entrypoint to swagger ui" do
    get "/api-docs"

    assert_response :redirect
    assert_redirected_to "/swagger/index.html"
  end
end
