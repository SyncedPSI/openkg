class Api::V2::NodesController < ApplicationController
  def show
    node = find_node_by_id(params[:id])
    result = node.properties.as_json
    result[:label] = (node.labels & types)[0]
    result[:children] = get_node_tree(params[:id], params[:id])
    render json: result.to_json
  end

  private

  def get_node_tree(node_id, parent_id, level = 0)
    level += 1
    if level < 3
      query_obj = 'MATCH (n)<-[r]->(a) WHERE n.uuid={id} AND a.uuid <> {parent_id} RETURN a.uuid, a.name, labels(a)'
      nodes = Neo4j::ActiveBase.current_session.query(query_obj, id: node_id, parent_id: parent_id).rows
      nodes.map { |n| { id: n[0], name: n[1], label: n[2][0], children: get_node_tree(n[0], node_id, level) } }
    else
      []
    end
  end
end
