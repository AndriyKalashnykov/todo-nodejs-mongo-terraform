import { ReactPlugin } from "@microsoft/applicationinsights-react-js";
import { ApplicationInsights, Snippet, ITelemetryItem } from "@microsoft/applicationinsights-web";
import { DistributedTracingModes } from "@microsoft/applicationinsights-common";
import config from "../config";

const plugin = new ReactPlugin();
let applicationInsights: ApplicationInsights;
export const reactPlugin = plugin;

export const getApplicationInsights = (): ApplicationInsights => {
    if (applicationInsights) {
        return applicationInsights;
    }

    const ApplicationInsightsConfig: Snippet = {
        config: {
            connectionString: config.observability.connectionString,
            enableCorsCorrelation: true,
            enableAutoRouteTracking: true,
            distributedTracingMode: DistributedTracingModes.W3C,
            extensions: [plugin],
        }
    }

    applicationInsights = new ApplicationInsights(ApplicationInsightsConfig);
    try {
        applicationInsights.loadAppInsights();
        applicationInsights.addTelemetryInitializer((telemetry: ITelemetryItem) => {
            if (!telemetry) {
                return;
            }
            if (telemetry.tags) {
                telemetry.tags['ai.cloud.role'] = "webui";
            }
        });
    } catch(err) {
        // TODO - proper logging for web
        console.error("ApplicationInsights setup failed, ensure environment variable 'VITE_APPLICATIONINSIGHTS_CONNECTION_STRING' has been set.", err);
    }

    return applicationInsights;
}

export const trackEvent = (eventName: string, properties?: { [key: string]: unknown }): void => {
    if (!applicationInsights) {
        return;
    }

    applicationInsights.trackEvent({
        name: eventName,
        properties: properties
    });
}
