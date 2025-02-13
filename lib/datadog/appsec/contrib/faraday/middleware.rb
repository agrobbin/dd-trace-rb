# frozen_string_literal: true

module Datadog
  module AppSec
    module Contrib
      module Faraday
        # Middleware for Faraday
        class Middleware < ::Faraday::Middleware
          def call(request_env)
            context = AppSec.active_context

            if context && AppSec.rasp_enabled?
              ephemeral_data = {
                'server.io.net.url' => request_env.url.to_s
              }

              result = AppSec.active_context.run_rasp(
                Ext::RASP_SSRF, {}, ephemeral_data, Datadog.configuration.appsec.waf_timeout
              )

              if result.match?
                Datadog::AppSec::Event.tag_and_keep!(context, result)

                context.events << {
                  waf_result: result,
                  trace: context.trace,
                  span: context.span,
                  request_url: request_env.url,
                  actions: result.actions
                }

                ActionsHandler.handle(result.actions)
              end
            end

            @app.call(request_env)
          end
        end
      end
    end
  end
end
