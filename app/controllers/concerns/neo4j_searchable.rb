module Neo4jSearchable
  extend ActiveSupport::Concern

  private

  def get_nodes_find_with_alias(name)
    query = 'MATCH (n)<-[:alias_of*0..1]-(a) WHERE (n:Technology OR n:Expert OR n:Institution OR n:Paper OR n:Venue) ' \
      'AND (a.name =~ {name}) AND NOT(n)-[:alias_of]->() RETURN n.uuid, n.name'
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
end