import React from "react";
import { CSSTransition } from "react-transition-group";

export const FadeTransition = props => <CSSTransition {...props} classNames="fade-in" timeout={300} />;
