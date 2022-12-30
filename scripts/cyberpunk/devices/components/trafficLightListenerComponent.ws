importonly class TrafficLightChangeEvent extends Event
{
	import var lightColor : worldTrafficLightColor;
}

import class TrafficLightListenerComponent extends IComponent
{
}

import enum worldTrafficLightColor
{
	GREEN,
	RED,
	YELLOW,
	INVALID,
}

