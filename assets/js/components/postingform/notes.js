import React from "react";

export default class Notes extends React.PureComponent {
  render() {
    return (
      <ul id="charta">
        <li>
          Formulieren Sie bitte{" "}
          <a href="https://wiki.selfhtml.org/wiki/SELFHTML:Forum/Charta_des_SELFHTML-Forums">
            <strong>höflich und wertschätzend</strong>
          </a>
          .
        </li>
        <li>
          Im Wiki erhalten Sie{" "}
          <a href="https://wiki.selfhtml.org/wiki/SELFHTML:Forum/Bedienung">
            <strong>Hilfe bei der Formatierung Ihrer Beiträge</strong>
          </a>
          .
        </li>
        <li>
          Ihr Beitrag wird <strong>dauerhaft</strong> <a href="//forum.selfhtml.org/all/archive">archiviert</a>.
        </li>
      </ul>
    );
  }
}
