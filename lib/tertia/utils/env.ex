defmodule Tertia.Utils.Env do
  defmacro only_in_envs(envs, do: block) do
    if Application.get_env(:tertia, :env) in envs do
      block
    end
  end
end
