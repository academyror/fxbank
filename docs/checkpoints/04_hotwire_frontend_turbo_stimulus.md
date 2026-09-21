# Checkpoint 04: Hotwire Frontend (Turbo & Stimulus)

- **Branch:** [`section/04-hotwire-frontend-turbo-stimulus`](https://github.com/academyror/fxbank/tree/section/04-hotwire-frontend-turbo-stimulus)
- **Tag:** `v0.4-section-4`
- **Course Lesson:** Section 4 at [rubyonrails.academy](https://www.rubyonrails.academy)

---

## Key Architectural Decisions

1. **Hotwire Turbo Architecture**:
   - **Turbo Drive**: Fast SPA transitions without heavy JS bundles; HTTP 303 See Other on success, HTTP 422 Unprocessable Content on validation failure.
   - **Turbo Frames**: Inline modal money transfer drawer (`turbo_frame_tag "transfer_modal"`) preventing full page refresh.
   - **Turbo Streams**: Real-time prepend into transaction ledger (`#transfers_list`) and in-place account balance replacement.

2. **Stimulus Controllers**:
   - `clipboard_controller.js`: Copy account numbers with immediate visual confirmation ("Copied!").
   - `currency_input_controller.js`: Live dollar-to-cent conversion and preview.
   - `modal_controller.js`: Modal dismiss on backdrop click and Escape key press.

---

## File Highlights in This Checkpoint

- `app/controllers/accounts_controller.rb` & `app/views/accounts/index.html.erb`
- `app/views/accounts/show.html.erb`
- `app/controllers/transfers_controller.rb`
- `app/views/transfers/new.html.erb` & `app/views/transfers/_form.html.erb`
- `app/views/transfers/_transfer.html.erb`
- `app/views/transfers/create.turbo_stream.erb`
- `app/javascript/controllers/`
