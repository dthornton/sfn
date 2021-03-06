require 'sfn'

module Sfn
  class Command
    # Update command
    class Update < Command

      include Sfn::CommandModule::Base
      include Sfn::CommandModule::Template
      include Sfn::CommandModule::Stack

      # Run the stack creation command
      def execute!
        name = name_args.first
        unless(name)
          ui.fatal "Formation name must be specified!"
          exit 1
        end

        stack_info = "#{ui.color('Name:', :bold)} #{name}"
        begin
          stack = provider.connection.stacks.get(name)
        rescue Miasma::Error::ApiError::RequestError
          stack = nil
        end

        if(config[:file])
          file = load_template_file(:stack => stack)
          stack_info << " #{ui.color('Path:', :bold)} #{config[:file]}"
          nested_stacks = file.delete('sfn_nested_stack')
        end

        if(nested_stacks)
          unpack_nesting(name, file, :update)
        else
          unless(stack)
            ui.fatal "Failed to locate requested stack: #{ui.color(name, :red, :bold)}"
            raise "Failed to locate stack: #{name}"
          end

          ui.info "#{ui.color('SparkleFormation:', :bold)} #{ui.color('update', :green)}"

          unless(file)
            if(config[:template])
              file = config[:template]
              stack_info << " #{ui.color('(template provided)', :green)}"
            else
              stack_info << " #{ui.color('(no template update)', :yellow)}"
            end
          end
          ui.info "  -> #{stack_info}"

          if(file)
            if(config[:print_only])
              ui.puts _format_json(translate_template(file))
              return
            end
            stack.template = translate_template(file)
            apply_stacks!(stack)
            populate_parameters!(file, :current_parameters => stack.parameters)
            stack.parameters = config_root_parameters
            stack.template = Sfn::Utils::StackParameterScrubber.scrub!(stack.template)
          else
            apply_stacks!(stack)
            populate_parameters!(stack.template, :current_parameters => stack.parameters)
            stack.parameters = config_root_parameters
          end

          begin
            api_action!(:api_stack => stack) do
              stack.save
              if(config[:poll])
                poll_stack(stack.name)
                if(stack.reload.state == :update_complete)
                  ui.info "Stack update complete: #{ui.color('SUCCESS', :green)}"
                  namespace.const_get(:Describe).new({:outputs => true}, [name]).execute!
                else
                  ui.fatal "Update of stack #{ui.color(name, :bold)}: #{ui.color('FAILED', :red, :bold)}"
                  raise
                end
              else
                ui.warn 'Stack state polling has been disabled.'
                ui.info "Stack update initialized for #{ui.color(name, :green)}"
              end
            end
          rescue Miasma::Error::ApiError::RequestError => e
            if(e.message.downcase.include?('no updates'))
              ui.warn "No updates detected for stack (#{stack.name})"
            else
              raise
            end
          end

        end
      end

    end
  end
end
