class WelcomeMsg extends React.Component {
    render() {
        return e('h1','Hello, {this.props.name}!');
    }
}

// Find all DOM containers, and render Like buttons into them.
document.querySelector('#welcome_msg_container').appendChild(domContainer => {
    const name = domContainer.dataset.name;
    root.render(
        e(WelcomeMsg, { name: name })
    );
});