# ⏱ hack-a-day-a-action-cable-a!

This is a very basic demo repo to showcase how to use turbo streams and broadcasting. An easier way to action cable

### 🏯 Architecture

This isn't a complete app - there's a few things you could change here. But the general structure goes

Users:
  - Name
  - Email
  - Password

Users Can:
  - Login
  - Logout
  - Send messages

Users Have:
  - Many conversations
  - Many messages

There's a few other things happening here that don't really matter, like we use tailwind!

## 📚 Helpful Resources

- [Turbo Handbook](https://turbo.hotwired.dev/handbook)
- [Hotrails Guide To Turbo](https://www.hotrails.dev/turbo-rails/turbo-streams)

## Getting Started

Run the following commands to get your app setup
`bin/setup`
`bin/dev`

You should then be running the app locally.

What Is `bin/setup` Doing Under The Hood?
- Creating a db
- Migrating all the tables we need
- Seeding the database with:
  - 2 users:
    - Name: Nick, email: nick.havilah@tanda.co, password: password
    - Name: Josh, email: josh@tanda.co, password: password
  - A conversation between Nick and Josh

What Is `bin/dev` Doing Under The Hood?
- Listening for changes to tailwindcss(in your views) and recompiling as needed(cool because you don't need to save your tailwindcss file to git because it builds at runtime)
- Starting the server

## What's The Purpose Of This App?

This app aims to provide a basic primer to using turbo and broadcasting. This is very similar to action cable.

## Why Not Demo Action Cable?

Action cable is really hard to work with, and uses a lot of custom javascript to add listeners. Seeing as we are moving away from adding a lot of vanilla javascript, and moving towards stimulus I thought this app should also follow this approach.

Fortunately turbo has a fun way that you can get real time updates, which we will be exploring in this app.

## Problem

No problems here to solve. Just learning!

First, check out `app/controllers/sessions_controller.rb`. This is important for showing real time updates for other users. Turbo is useful for updating the current user's view on the fly. This controller just allows us to login and logout. We use bcrypt to handle password authentication to keep things simple. Now we can login as either Nick or Josh.

Once we login, we get redirected to a list links of conversations. Seeding the database gives us one to start with. Otherwise you'll have to create new ones via the console. You can click on a link and go to a specific conversation between you and whoever you're chatting with.

The conversation page structure looks like this:
- A turbo_stream_from the conversation, with the id "messages"
- A div with the id "messages" that renders all the messages
- The message form, or the text input for you to send messages

What Happens When You Send A Message?
- The form sends a request to `create_message_path` on the messages controller(`app/controllers/messages_controller.rb #create`)
- The controller finds the conversation, and creates a new message attached to it
- If it can save the message, it'll return the turbo stream that appends the new message to the list of messages
- If it cannot save the message, it errors out
- The turbo stream appends the message to the div with the id "messages"(`app/views/messages/create.turbo_stream.haml`)
- The turbo stream also replaces the form partial with a new, giving the appearance of resetting the form

Now this on its own is great, as this allows a user to send a message and it looks like it updates the sent messages(the usual turbo things).

You'll notice however, if you have 2 sessions running side by side(one for Nick and one for Josh), the recipient of the message doesn't get updated like the sender does. This happens because the user receiving the update is the one sending the message, as the turbo stream is a response to the form submission.

Fear not, there's a fix for this!

Take a look in `app/models/message.rb`. You'll see some of the usual association stuff, and also this one line

```
broadcasts_to ->(message) { [message.conversation, "messages"] }, inserts_by: :prepend, partial: "conversations/message"
```
[Useful Documentation](https://rubydoc.info/github/hotwired/turbo-rails/Turbo%2FBroadcastable%2FClassMethods:broadcasts_to)

This is how we can broadcast for other users to receive messages live. Let's break it down:
- It uses a lambda function to provide some parameters and use itself as an argument
- The array `[message.conversation, "messages"]` is the target stream. Think of it like how you'd target a div with your turbo stream. The `message.conversation` allows you to scope it to just your conversation. This prevents you from accidentally broadcasting messages to other users' conversations, which is important in chat apps.
- `inserts_by` is very similar to turbo streams and how you can choose how the stream appends data. I use prepend because of some scoping on the messages to show newest messages first
- partial allows you to tell the model how you want to render it. Not always needed. Unlike this app, you could have yours structured so the messages are rendered using `messages/_message` instead. This is something neat I found that you might find useful
- There is also an argument for target, but from what I've been able to work out you don't need it thanks to the scoping we did earlier

When you add this to the model, refresh both pages and send a message again, both users see the message! Voila!

## Interesting Limitations

One of the standard features of a chat app is that messages are styled differently if you send or receive them. You'd think you could use something like
```
- if message.user == current_user
  # do some styling
- else
  # do some other styling
```
And this works fine for when you first open the chat and look at messages you've sent. BUT there's a situation when this doesn't work.
When you send messages, the styling will look like you received a message when you actually sent the message. This isn't ideal. Any ideas what's happening?

If you guessed that `current_user` doesn't exist in the turbo stream, you'd almost be right. The turbo stream can see the current user fine. The broadcast can't though. Why? 
Turns out that the broadcast is using similar concepts to action cable under the hood, and broadcasts are session agnostic. This is what's allowing us to send messages to users in real time. It's a DHH special, and there's a few more reasons but I can't find them.

How Do We Get Around It Here?

Check out `app/views/conversations/show.html.haml`
See this CSS?
```
:css
  #{".msg-#{current_user&.id}"} {
  justify-content: flex-end
  }
  #{".content-#{current_user&.id}"} {
  background-color: rgb(37 99 235);
  }
```
It's a little jenky, because we aren't using the CSS like we would throughout the rest of the views, but if we pair it with this code in `app/views/conversations/_message.html.haml`
```
.flex{ class: "msg-#{message.user.id}"}
```
What we can do is conditionally apply CSS in the conversation, not the message. This allows us to broadcast messages, and the conversation(which has access to the concept of a current user and session) can style the messages for us. Neat right?

There's another way we could get around this too. Basically when you create the message in the messages controller, you can determine whether the owner of the message is the current user, and use a separate turbo stream to render it for that user. This will probably mean a separate partial, or just conditionals being passed into the partial, which could get complex quickly. Also not sure how well that works with the broadcasting, but I think there's some other tricks you could pass in to get that working. Personally, I prefer my approach because of its simplicity, but I'll leave that up to you.
