defmodule Tertia.SampleValues do
  @dummy_password "hello"
  def dummy_password(), do: @dummy_password

  def user() do
    {public_key, encrypted_priv} = Tertia.Utils.Crypto.gen_auth_pair(@dummy_password)

    %{
      status: "active",
      name: "Terry",
      username: "terry",
      email: "terry@email.com",
      token: Ecto.UUID.generate(),
      location: Tertia.Utils.RepoUtils.build_point(10.1, 20.1),
      password: @dummy_password,
      public_key: public_key,
      encrypted_private_key: encrypted_priv
    }
  end

  def channel() do
    %{
      name: "personal",
      type: "personal"
    }
  end

  def message() do
    %{
      type: "text",
      text: "test blah"
    }
  end

  def user_channel_assoc() do
    %{
      type: "personal"
    }
  end
end
