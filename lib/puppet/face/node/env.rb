require 'puppet/face'
require 'puppet/util/terminal'
require 'puppet/util/colors'

Puppet::Face.define(:node, '0.0.1') do
  extend Puppet::Util::Colors
  action :env do
    summary "Return the environments of nodes from the yaml terminus"
    arguments "node"

    description <<-'EOT'
      stuff
    EOT
    notes <<-'NOTES'
      things
    NOTES
    examples <<-'EOT'
      Compare host catalogs:

      $ puppet environment <node_name>
    EOT

    when_invoked do |node_name, options|
      Puppet[:clientyamldir] = Puppet[:yamldir]
      output = [ {'Name' => 'Environment'} ]
      if node_name == '*'
       Puppet::Node.indirection.terminus_class = :yaml
        unless nodes = Puppet::Node.indirection.search(node_name)
          raise "Nothing returned from yaml terminus (yamldir set?)"
        end
        output << nodes.map { |node| Hash[node.name => node.environment] }
        output.flatten
      else
        unless node = Puppet::Node.indirection.find(node_name,:terminus => 'yaml' )
          raise "Nothing returned from yaml terminus for (#{node_name})"
        end
        clientcert = node.parameters['clientcert']
        raise "Results returned (#{clientcert})" if clientcert != node_name
        output << Hash[ node.name => node.environment]
        output
      end
    end

    when_rendering :console do |output|
      padding = '  '
      headers = {
        'node_name'   => 'Name',
        'environment' => 'Environment',
      }

      min_widths = Hash[ *headers.map { |k,v| [k, v.length] }.flatten ]
      min_widths['node_name'] = min_widths['environment'] = 80

      min_width = min_widths.inject(0) { |sum,pair| sum += pair.last } + (padding.length * (headers.length - 1))

      terminal_width = [Puppet::Util::Terminal.width, min_width].max

      highlight = proc do |color,s|
        c = colorize(color, s)
        c
      end
      n = 0
      output.collect do |results|

        columns = results.inject(min_widths) do |node_name,environment|
          {
            'node_name'   => node_name.length,
            'environment' => environment.length,
          }
        end

        flex_width = terminal_width - columns['node_name'] - columns['environment'] - (padding.length * (headers.length - 1))

        format = %w{node_name environment}.map do |k|
          "%-#{ [ columns[k], min_widths[k] ].max }s"
        end.join(padding)
        results.map do |node_name,environment|
          n += 1
          if n.odd?
            highlight[ :hwhite,format % [ node_name, environment ] ]
          else
            highlight[ :white,format % [ node_name, environment ] ]
          end
        end.join
      end
    end
  end
end
