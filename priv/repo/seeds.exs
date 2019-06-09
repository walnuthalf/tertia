# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Tertia.Repo.insert!(%Tertia.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
terry =
  Tertia.UserCommands.add_user!(%{
    status: "active",
    name: "Terry",
    username: "terry",
    email: "terry@email.com",
    location: Tertia.Utils.RepoUtils.build_point(10.1, 20.1),
    password: "hello"
  })

steve =
  Tertia.UserCommands.add_user!(%{
    status: "active",
    name: "Steve",
    username: "steve",
    email: "steve@email.com",
    location: Tertia.Utils.RepoUtils.build_point(10.1, 20.1),
    password: "hello"
  })

channel = Tertia.ChatCommands.create_personal_channel!(steve.id, terry.id)

Tertia.ChatCommands.insert_text_message!(%{
  channel_id: channel.id,
  user_id: terry.id,
  text: "test terry"
})

Tertia.ChatCommands.insert_text_message!(%{
  channel_id: channel.id,
  user_id: steve.id,
  text: "test steve"
})
