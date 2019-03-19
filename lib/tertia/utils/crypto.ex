defmodule Tertia.Utils.Crypto do
  @aes_key_size 16
  @curve :brainpoolP256r1
  @key_algorithm :ecdh

  def encrypt(data, password) do
    :crypto.block_encrypt(:aes_ecb, prepare_password(password), data)
  end

  def decrypt(data, password) do
    :crypto.block_decrypt(:aes_ecb, prepare_password(password), data)
  end

  def pad(data, block_size) do
    # if remainder is zero, then gotta add a whole block just for the last byte
    diff = rem(byte_size(data), block_size)

    to_add = (diff == 0 && block_size) || block_size - diff
    data <> to_string(:string.chars(to_add, to_add))
  end

  def unpad(data) do
    to_remove = :binary.last(data)
    :binary.part(data, 0, byte_size(data) - to_remove)
  end

  def gen_auth_pair(password) do
    # priv is 32 bytes long
    {pub, priv} = :crypto.generate_key(@key_algorithm, @curve)
    {pub, encrypt(priv, password)}
  end

  def match_keys(pub, priv), do: auth_sign(priv) |> auth_verify(pub)

  def auth_sign(priv), do: :crypto.sign(:ecdsa, :sha256, "auth", [priv, @curve])

  def auth_verify(signature, public),
    do: :crypto.verify(:ecdsa, :sha256, "auth", signature, [public, @curve])

  def prepare_password(password) when byte_size(password) >= @aes_key_size,
    do: String.slice(password, 0..(@aes_key_size - 1))

  def prepare_password(password), do: pad(password, @aes_key_size)
end
