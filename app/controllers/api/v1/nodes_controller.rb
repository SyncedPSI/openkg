class Api::V1::NodesController < ApplicationController
  def show
    node = find_node_id_name(params[:id])
    node_out = related_out(params[:id])
    node_in = related_in(params[:id])
    result = build_json(node, node_in, node_out)
    node_info = find_node_by_id(params[:id])
    result[:id] = node_info.properties[:uuid]
    result[:name] = node_info.properties[:name]
    result[:desc] = node_info.properties[:desc]
    render json: result.to_json
  end

  private

  def build_json(node, node_in, node_out)
    result = {}
    result[:nodes] = nodes_json_format(node + node_in + node_out)
    result[:links] = links_json_format(node, node_in, node_out)
    result
  end

  def nodes_json_format(nodes)
    nodes.map { |node| { id: node[0], name: node[1] } }
  end

  def links_json_format(node, node_in, node_out)
    link_in = node_in.map { |n| { source: n[0], target: node[0][0] } }
    link_out = node_out.map { |n| { source: node[0][0], target: n[0] } }
    link_in + link_out
  end
end
