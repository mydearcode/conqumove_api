class ApiDocsController < ActionController::API
  def openapi
    response.headers["Cache-Control"] = "no-store"
    render plain: Rails.root.join("docs/openapi.yaml").read, content_type: "application/yaml"
  end
end
