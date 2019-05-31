use rnix::{
    SyntaxNode, SyntaxToken, SyntaxElement, WalkEvent,
    tokenizer::tokens::TOKEN_WHITESPACE
};


pub(crate) fn walk<'a>(node: &'a SyntaxNode) -> impl Iterator<Item = SyntaxElement<'a>> {
    node.preorder_with_tokens().filter_map(|event| match event {
        WalkEvent::Leave(_) => None,
        WalkEvent::Enter(element) => Some(element),
    })
}
pub(crate) fn walk_non_whitespace<'a>(node: &'a SyntaxNode) -> impl Iterator<Item = SyntaxElement<'a>> {
    node.preorder_with_tokens().filter_map(|event| match event {
        WalkEvent::Leave(_) => None,
        WalkEvent::Enter(element) => Some(element).filter(|it| it.kind() != TOKEN_WHITESPACE),
    })
}
pub(crate) fn walk_tokens<'a>(node: &'a SyntaxNode) -> impl Iterator<Item = SyntaxToken<'a>> {
    walk(node).filter_map(|element| match element {
        SyntaxElement::Token(token) => Some(token),
        _ => None,
    })
}

pub(crate) fn has_newline(node: &SyntaxNode) -> bool {
    walk_tokens(node).any(|it| it.text().contains('\n'))
}