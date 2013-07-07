class <%= class_prefix %>Form < Reform::Form
  include DSL
<%- unless skip_activerecord? -%>
  include Reform::Form::ActiveRecord
<%- end -%>

<%- properties.keys.each do |model|
  names = properties[model]
  -%>
<%- if names.length == 1 -%>
  property :<%= names[0] %>, on: :<%= model %>
  <%- else -%>
  properties [<%= names.map {|name| ":#{name}"}.join(", ") %>], on: :<%= model %>
<%- end -%>
<% end %>
<%- if has_model? -%>
  model :<%= model %>
<%- end -%>

end
