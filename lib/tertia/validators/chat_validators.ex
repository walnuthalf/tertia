defmodule Tertia.ChatValidators do
  alias Tertia.{ChatQueries, Utils.Validators}

  def validate_user_channel(user_id, channel_id) do
    Validators.validate_true(
      ChatQueries.user_in_channel?(user_id, channel_id),
      "you are not in channel #{channel_id}"
    )
  end
end
