defmodule Cforum.RedirectionFactory do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.System.Redirection

      def redirection_factory do
        %Redirection{
          path: sequence("/foo"),
          destination: sequence("/bar"),
          http_status: 301
        }
      end
    end
  end
end
