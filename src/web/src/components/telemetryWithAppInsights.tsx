import { ComponentType } from 'react';
import { reactPlugin } from '../services/telemetryService';
import { withAITracking } from '@microsoft/applicationinsights-react-js';

const withApplicationInsights = <P extends object>(component: ComponentType<P>, componentName: string) =>
    withAITracking(reactPlugin, component, componentName);

export default withApplicationInsights;
