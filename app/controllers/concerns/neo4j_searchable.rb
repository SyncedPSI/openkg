module Neo4jSearchable
  extend ActiveSupport::Concern

  private

  def get_nodes_find_with_alias(name)
    query = 'MATCH (n)<-[:alias_of*0..1]-(a) WHERE' \
      '(a.name =~ {name}) AND NOT(n)-[:alias_of]->() AND a.uuid <> "" ' \
      'RETURN n.uuid, n.name, labels(n)  LIMIT 50'
    Neo4j::ActiveBase.current_session.query(query, name: "(?i).*#{name}.*").rows
  end

  def find_node_id_name(id)
    Neo4j::ActiveBase.current_session.query('MATCH (n) WHERE n.uuid={id} RETURN n.uuid, n.name', id: id).rows
  end

  def related_out(id)
    Neo4j::ActiveBase.current_session.query('MATCH (n)-[]->(a) WHERE n.uuid={id} RETURN a.uuid, a.name',id: id).rows
  end

  def related_in(id)
    Neo4j::ActiveBase.current_session.query('MATCH (n)<-[]-(a) WHERE n.uuid={id} RETURN a.uuid, a.name',id: id).rows
  end

  def find_node_by_id(id)
    Neo4j::ActiveBase.current_session.query('MATCH (n) WHERE n.uuid={id} RETURN n', id: id).rows.flatten.first
  end

  # def node_related(id)
  #   query_in = 'MATCH (n)<-[r]-(a) WHERE n.uuid={id} RETURN a.uuid, a.name, labels(a), type(r)'
  #   query_out = 'MATCH (n)-[r]->(a) WHERE n.uuid={id} RETURN a.uuid, a.name, labels(a), type(r)'
  #   relationship_in = Neo4j::ActiveBase.current_session.query(query_in, id: id).rows
  #   relationship_out = Neo4j::ActiveBase.current_session.query(query_out, id: id).rows
  #   nodes = (relationship_in + relationship_out).map { |n| { id: n[0], name: n[1], label: n[2][0] } }
  #   links_in = relationship_in.map { |n| { source: n[0], target: id } }
  #   links_out = relationship_out.map { |n| { source: id, target: n[0] } }
  #   [nodes, (links_in + links_out)]
  # end
end
