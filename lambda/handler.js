exports.handler = (event) => {
  if (event.Records[0]?.body) {
    const { message } = JSON.parse(event.Records[0].body);
    if (message) {
      return console.log(message);
    }
  }
  throw Error('invalid event');
};
