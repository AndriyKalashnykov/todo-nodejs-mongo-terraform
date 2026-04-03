import { TelemetryClient, KnownSeverityLevel, TraceTelemetry } from "applicationinsights";
import Transport, { TransportStreamOptions } from "winston-transport";
import { LogEntry } from "winston";
import { LogLevel } from "./observability";

export interface ApplicationInsightsTransportOptions extends TransportStreamOptions {
    client: TelemetryClient
    handleRejections?: boolean;
}

export class ApplicationInsightsTransport extends Transport {
    private client: TelemetryClient;

    constructor(opts: ApplicationInsightsTransportOptions) {
        super(opts);
        this.client = opts.client;
    }

    public log(info: LogEntry, callback: () => void) {
        const telemetry: TraceTelemetry = {
            severity: convertToSeverity(info.level),
            message: info.message,
        };

        this.client.trackTrace(telemetry);
        callback();
    }
}

const convertToSeverity = (level: LogLevel | string): KnownSeverityLevel => {
    switch (level) {
    case LogLevel.Debug:
        return KnownSeverityLevel.Verbose;
    case LogLevel.Verbose:
        return KnownSeverityLevel.Verbose;
    case LogLevel.Error:
        return KnownSeverityLevel.Error;
    case LogLevel.Warning:
        return KnownSeverityLevel.Warning;
    case LogLevel.Information:
        return KnownSeverityLevel.Information;
    default:
        return KnownSeverityLevel.Verbose;
    }
};