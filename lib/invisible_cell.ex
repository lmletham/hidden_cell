defmodule InvisibleCell do
  use Kino.JS
  use Kino.JS.Live
  use Kino.SmartCell, name: "Invisible Cell 2"

  @impl true
  def init(attrs, ctx) do
    source = attrs["source"] || ""
    title = attrs["title"] || "Invisible Cell"
    {:ok, assign(ctx, source: source, title: title)}
  end

  @impl true
  def handle_connect(ctx) do
    {:ok, %{source: ctx.assigns.source, title: ctx.assigns.title}, ctx}
  end

  @impl true
  def handle_event("update_source", %{"source" => source}, ctx) do
    broadcast_event(ctx, "update_source", %{"source" => source})
    {:noreply, assign(ctx, source: source)}
  end

  def handle_event("update_title", %{"title" => title}, ctx) do
    broadcast_event(ctx, "update_title", %{"title" => title})
    {:noreply, assign(ctx, title: title)}
  end

  @impl true
  def to_attrs(ctx) do
    %{"source" => ctx.assigns.source, "title" => ctx.assigns.title}
  end

  @impl true
  def to_source(attrs) do
    attrs["source"]
  end

  asset "main.js" do
    """
    export function init(ctx, payload) {
      ctx.importCSS("main.css");

      ctx.root.innerHTML = `
        <section id="container">
          <p id="title">${payload.title}</p>
          <input id="title_input"></input>
          <textarea id="source"></textarea>
        </section>
      `;

      const textarea = ctx.root.querySelector("#source");
      const title = ctx.root.querySelector("#title");
      const title_input = ctx.root.querySelector("#title_input");
      const container = ctx.root.querySelector("#container");

      textarea.style.display = "none"
      textarea.value = payload.source;

      title_input.style.display = "none"
      title_input.value = payload.title;

      textarea.addEventListener("change", (event) => {
        ctx.pushEvent("update_source", { source: event.target.value });
      });

      title_input.addEventListener("change", (event) => {
        ctx.pushEvent("update_title", { title: event.target.value });
      });

      title.addEventListener("dblclick", (event) => {
        if (textarea.style.display == "none") {
          textarea.style.display = "block"
          title_input.style.display = "block"
        } else {
          textarea.style.display = "none"
          title_input.style.display = "none"
        }
      });

      ctx.handleEvent("update_source", ({ source }) => {
        textarea.value = source;
      });

      ctx.handleEvent("update_title", ({ title: title_text }) => {
        title.innerHTML = title_text;
        title_input.value = title_text;
      });

      ctx.handleSync(() => {
        // Synchronously invokes change listeners
        document.activeElement &&
          document.activeElement.dispatchEvent(new Event("change"));
      });
    }
    """
  end

  asset "main.css" do
    """
    #source {
      min-height: 20px;
    }

    #container {
      background-color: rgb(255 255 255);
      font-weight: 500;
      color: rgb(255 255 255);
      font-family: Inter, system-ui,-apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif, Apple Color Emoji, Segoe UI Emoji;
    }

    #title_input, #source {
      width: 100%;
      margin: 0.5rem 0;
      box-sizing: border-box;
    }
    #title {
      text-align: left;
      cursor: pointer;
    }
    """
  end
end
