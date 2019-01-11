json.items @nodes do |node|
  json.call(node, :id, :name)
end
