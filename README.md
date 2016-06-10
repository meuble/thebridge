During the #linc16 Hackathon, we put together The Bridge.
 
The Bridge is a Facebook bot. Listening to a specific Facebook Page Messenger conversations, it take users questions and search into the community for matching contents. If relevant contents is found, the bot pushes them to the user through structured messages in Facebook Messenger.
 
From those contents, the user can then choose between going to the community to either read the content (and hopefully engage himself) or ask his question in a post.
Ultimately, he can choose to talk to a brand representative via the same Messenger conversation. The conversation is then displayed to an agent in LSW (according to specific settings in queues).
 
During the time of the hackathon, we just blindly covered an answer to every statement made on Messenger (being a question or not, being relevant to the community or not) and the search in the community is a blind matching from posts subjects.
We could improve the bot to search to specific parts of the community, also search through posts body or filter on answered topics. We could also order the displayed contents by relevancy or by comments count. And implement a "more content" button.
 
This cover the "content from community to messenger" part. A scenario could be explored where the user contributes to the community directly from messenger. This won't be trivial, as we would have to deal with identity matching (Facebook <=> Community).
 
You'll find in attachment the deck of slide presenting the concept.
The following video will show you practically how this basic hack works and the final result on desktop or mobile of this integration: https://youtu.be/l7Vf6U8eXM0

You can find the source code of The Bridge bot on github : https://github.com/meuble/thebridge
 
The team was composed of :
 - John Linster (QVC)
 - Amy Trice (QVC) 
 - Keyai Lee (Comcast)
 - Stéphane Akkaoui (The Social Client)
 
If you have any questions regarding this code, or the configuration needed in both Lithium LSW or Facebook (yes, you do need that…), feel free to reach out to me.
If you are interested into designing bot experiences for your customers don't hesitate to contact The Social Client.
