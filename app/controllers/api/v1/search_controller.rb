class Api::V1::SearchController < ApplicationController
  def index
    keyword = params[:keyword]
    @nodes = get_nodes_find_with_alias(keyword)
    render json: node_format(@nodes).to_json
  end

  private

  def node_format(nodes)
    nodes.map { |n| { id: n[0], name: n[1] } }
  end
end
