# We have customised the `gem` provider for the `package` type which
# installs gems into the system Ruby and ignore the rbenv environment that
# we run Puppet from.
#
# This check makes people use that customised provider, called `system_gem`,
# instead of the stock one which won't behave how they intend.
#
# We don't currently have a need to install gems into rbenv. In the unlikely
# event that we do in the future then we may need to change this.
#
PuppetLint.new_check(:gem_provider) do
  def check
    resource_indexes.each do |resource|
      if resource[:type].value == 'package'
        resource[:param_tokens].select{ |resource_token|
          resource_token.type == :NAME and resource_token.value == 'provider'
        }.each do |resource_token|
          value_token = resource_token.next_code_token.next_code_token
          notify :error, {
            :message    => "Use 'system_gem' provider instead of 'gem'",
            :line       => value_token.line,
            :column     => value_token.column,
          } if value_token.value == 'gem'
        end
      end
    end
  end
end
