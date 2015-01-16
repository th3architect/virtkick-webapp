module RequirejsHelper

  def requirejs_include_tag name = nil

    requireConfigFile = YAML.load_file(Rails.root.join('config', 'requirejs.yml'))

    html = ''
    html += '<script src="/require.js"></script>'

    if Rails.env.production? 
        requireConfig = {"baseUrl" => "/javascripts"}
    else
        requireConfig = {"baseUrl" => "/assets"}
    end
    
    requireConfig = requireConfig.merge(
      {"shim" => requireConfigFile["shim"]}
    ) if requireConfigFile["shim"]

    html +=
'''
<script>
require.config(
'''
    html += requireConfig.to_json
    html += 
'''
);
'''

    html += 'require(["' + name + '"]);'
    html +=
'''
</script>
'''
    html.html_safe
  end
end