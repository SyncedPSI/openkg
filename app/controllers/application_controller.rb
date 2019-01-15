class ApplicationController < ActionController::API
  include Neo4jSearchable

  private

  def types
    %i[Technology Expert Venue Institution Paper Solution Resource BusinessCase]
  end
end
