import consumer from "./consumer";

window.startOrderChannel = function(account_id){
  consumer.subscriptions.create({
      channel: "OrderChannel",
      account_id: account_id,
    },
    {
      connected(data){
        console.log("Connected to Order Channel for Account " + account_id);
      },
      received(data){
        console.log("New Order for Account " + account_id + ' - Order: ' + data['data']['order_id']);

        switch(data['action']){
          case 'new_order':
          $.ajax({
            method: 'GET',
            url: "/orders/" + data['data']['order_id'] + '.js',
           });

          break;
        }
      }
    }
  );
}
