import React from "react";
import { render } from "react-dom";
import { CSSTransitionGroup } from "react-transition-group";

import { t } from "./modules/i18n";
import { uniqueId } from "./modules/helpers";

class AlertsContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = { alerts: [...this.props.existingAlerts] };

    this.state.alerts.filter(alrt => alrt.type == "success").forEach(alrt => {
      window.setTimeout(() => this.removeAlert(alrt), 10000);
    });
  }

  removeAlert(alert) {
    this.setState({ ...this.state, alerts: this.state.alerts.filter(alrt => alrt.id != alert.id) });
  }

  addAlert(alert) {
    const id = alert.id || uniqueId();
    const alrtWithId = { ...alert, id: id };

    this.setState({
      ...this.state,
      alerts: [...this.state.alerts, alrtWithId]
    });

    if (alrtWithId.type == "success") {
      window.setTimeout(() => this.removeAlert(alrtWithId), 10000);
    }
  }

  render() {
    return (
      <CSSTransitionGroup
        component="div"
        transitionName="fade-in"
        transitionEnterTimeout={300}
        transitionLeaveTimeout={300}
      >
        {this.state.alerts.map(alert => (
          <div
            key={alert.id}
            className={`cf-${alert.type} cf-alert fade in`}
            role="alert"
            onClick={() => this.removeAlert(alert)}
          >
            <button type="button" className="close" aria-label={t("close")}>
              <span aria-hidden="true">&times;</span>
            </button>
            {alert.text}
          </div>
        ))}
      </CSSTransitionGroup>
    );
  }
}

let alertsContainer = null;
document.addEventListener("DOMContentLoaded", () => {
  const elem = document.querySelector("#alerts-container");
  const existingAlerts = Array.from(elem.querySelectorAll(".cf-alert")).map(alert => {
    return {
      id: uniqueId(),
      type: alert.classList.contains("cf-error") ? "error" : "success",
      text: alert.querySelector("button").nextSibling.textContent
    };
  });

  render(
    <AlertsContainer
      ref={cnt => {
        alertsContainer = cnt;
      }}
      existingAlerts={existingAlerts}
    />,
    elem
  );
});

export const alert = (type, text) => alertsContainer.addAlert({ type, text });
export const alertError = text => alert("error", text);
export const alertSuccess = text => alert("success", text);
