import React from "react";
import { render } from "react-dom";
import { TransitionGroup } from "react-transition-group";
import { FadeTransition } from "./components/transitions";

import { t } from "./modules/i18n";
import { uniqueId } from "./modules/helpers";

const SUCCESS_TIMEOUT = 5;
const INFO_TIMEOUT = 10;
const ERROR_TIMEOUT = 0;

class AlertsContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = { alerts: [...this.props.existingAlerts] };

    this.state.alerts
      .filter(alrt => !!alrt.timeout)
      .forEach(alrt => {
        window.setTimeout(() => this.removeAlert(alrt), alrt.timeout * 1000);
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

    if (alrtWithId.timeout) {
      window.setTimeout(() => this.removeAlert(alrtWithId), alrtWithId.timeout * 1000);
    }
  }

  render() {
    return (
      <TransitionGroup component="div">
        {this.state.alerts.map(alert => (
          <FadeTransition>
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
          </FadeTransition>
        ))}
      </TransitionGroup>
    );
  }
}

let alertsContainer = null;
document.addEventListener("DOMContentLoaded", () => {
  const elem = document.querySelector("#alerts-container");
  const existingAlerts = Array.from(elem.querySelectorAll(".cf-alert")).map(alert => {
    let type, timeout;
    if (alert.classList.contains("cf-error")) {
      type = "error";
      timeout = ERROR_TIMEOUT;
    } else if (alert.classList.contains("cf-success")) {
      type = "success";
      timeout = SUCCESS_TIMEOUT;
    } else {
      type = "info";
      timeout = INFO_TIMEOUT;
    }

    return {
      id: uniqueId(),
      type,
      timeout,
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

export const alert = (type, text, timeout) => alertsContainer.addAlert({ type, text, timeout });
export const alertError = (text, timeout = ERROR_TIMEOUT) => alert("error", text, timeout);
export const alertSuccess = (text, timeout = SUCCESS_TIMEOUT) => alert("success", text, timeout);
export const alertInfo = (text, timeout = INFO_TIMEOUT) => alert("info", text, timeout);
