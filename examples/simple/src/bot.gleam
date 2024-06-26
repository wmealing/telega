import gleam/erlang/process
import gleam/result
import gleam/option.{None, Some}
import mist
import wisp.{type Request, type Response}
import telega.{type Bot, type Context, HandleAll}
import telega/adapters/wisp as telega_wisp
import telega/api as telega_api

fn handle_request(bot: Bot, req: Request) -> Response {
  use <- telega_wisp.handle_bot(req, bot)
  wisp.not_found()
}

fn echo_handler(ctx: Context) {
  use <- telega.log_context(ctx, "echo")

  case ctx.message.raw.text {
    Some(text) ->
      telega_api.reply(ctx, text)
      |> result.map(fn(_) { Nil })
    None -> Error("No text in message")
  }
}

pub fn main() {
  wisp.configure_logger()
  let bot =
    telega.new(
      token: "your bot token from @BotFather",
      url: "your bot url",
      webhook_path: "secret path",
      secret_token: None,
    )
    |> telega.add_handler(HandleAll(echo_handler))

  let assert Ok(_) =
    wisp.mist_handler(handle_request(bot, _), wisp.random_string(64))
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http
    |> result.nil_error

  let assert Ok(_) = telega_api.set_webhook(bot)

  process.sleep_forever()
}
