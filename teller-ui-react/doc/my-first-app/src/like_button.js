'use strict';
// JavaScript 严格模式（strict mode）即在严格的条件下运行。 
// "use strict" 指令在 JavaScript 1.8.5 (ECMAScript5) 中新增。
// 它不是一条语句，但是是一个字面量表达式，在 JavaScript 旧版本中会被忽略。



const e = React.createElement;
/*ES2015(ES6) 新增加了两个重要的 JavaScript 关键字: let 和 const。
* let 声明的变量只在 let 命令所在的代码块内有效。
* const 声明一个只读的常量，一旦声明，常量的值就不能改变。
* 在 ES6 之前，JavaScript 只有两种作用域： 全局变量 与 函数内的局部变量。 
*/


class LikeButton extends React.Component {
    constructor(props) {
        super(props);
        this.state = { liked: false };
    }

    render() {
        if (this.state.liked) {
            return 'You liked comment number ' + this.props.commentID;
        }

        return e(
            'button',
            { onClick: () => this.setState({ liked: true }) },
            'Like'
        );
    }
}

// Find all DOM containers, and render Like buttons into them.
document.querySelectorAll('.like_button_container').forEach(
    domContainer => {
        // Read the comment ID from a data-* attribute.
        const commentID = parseInt(domContainer.dataset.commentid, 10);
        const root = ReactDOM.createRoot(domContainer);
        root.render(
            e(LikeButton, { commentID: commentID })
        );
    });