/*
Copyright (c) 2008, Nigel Batten.
Contactable at <firstname>.<lastname>@mail.com

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

	1.	Redistributions of source code must retain the above copyright
		notice, this list of conditions and the following disclaimer.
	2.	Redistributions in binary form must reproduce the above copyright
		notice, this list of conditions and the following disclaimer in the
		documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
COPYRIGHT HOLDER BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
OF SUCH DAMAGE.


A demonstration of binary code modulation LED dimming.
Nigel Batten, 2008

Written for a 'factory setting' Mega8 (highbyte: 0xd9, lowbyte:  0xe1)
e.g. running on 1Mhz internal RC oscillator.

Outputs a 'sweep' pattern on LEDs connected to port D.
Could be extended to handle more ports.
Could be modified to mask off pins used for other purposes.

*/

#include <avr/io.h>
#include <avr/interrupt.h>

// define the processor speed if it's not been defined at the compilers command line.
#ifndef F_CPU
#define F_CPU 1000000
#endif

volatile uint8_t g_timeslice[8] ; // one byte for each bit-position being displayed on a port.
volatile uint8_t g_tick = 0;
volatile uint8_t g_bitpos = 0; // which bit position is currently being shown

void led_init( void ) ;
void led_encode_timeslices( uint8_t a[] );


__attribute((OS_main)) int main(void)
{
uint8_t brightness[8]; // brightness for each LED on port D.

	led_init();
	led_encode_timeslices( brightness ) ;
	sei();


// now a (simple) demonstration...
// In the real-world, you'd probably want to decouple the
// animation speed from the LED flicker-rate.
uint8_t slowtick = 30;
uint8_t position = 0 ;
    while(1)
    {
		while(g_tick==0){ /*wait for g_tick to be non-zero*/ }
		g_tick = 0 ; //consume the tick
		// make each of the LEDs slightly dimmer...
		for ( uint8_t index = 0 ; index < 8 ; index++ )
		{
			if (brightness[ index ] > 0) brightness[ index ]-- ;
		}
		// once every 50 ticks, advance the head of the sweep...
		slowtick-- ;
		if (slowtick==0)
		{
			slowtick = 30;
			position++ ;
			position &= 7 ;
			brightness[ position ] = 100 ;
		}
		// and now re-encode all the timeslices...
		led_encode_timeslices( brightness ) ;
	}
    return(0);
}


// simple initialisation of the port and timer
void led_init( void )
{
	PORTD = 0x00 ; // All outputs to 0.
	DDRD = 0xff ; // All outputs.
	
	TCCR2 |= (1<<WGM21) ; // set the timer to CTC mode.
	TCCR2 |= ((1<<CS21)|(1<<CS20)) ; // use clock/32 tickrate
	g_bitpos = 0 ;
	OCR2 = 1 ; // initial delay.
	TIMSK |= (1 << OCIE2) ; // Enable the Compare Match interrupt
}


// encode an array of 8 LED brightness bytes into the pattern
// to be shown on the port for each of the 8 timeslices.
void led_encode_timeslices( uint8_t intensity[] )
{
	uint8_t portbits = 0;
	uint8_t bitvalue ;
	
	for ( uint8_t bitpos = 0 ; bitpos < 8 ; bitpos++ )
	{
		portbits = 0;
		bitvalue = 1 ;
		for ( uint8_t ledpos = 0 ; ledpos < 8 ; ledpos++ )
		{
			if (intensity[ ledpos ] & (1 << bitpos)) portbits |= bitvalue ;
			bitvalue = bitvalue << 1 ;
		}
		g_timeslice[ bitpos ] = portbits ;
	}
}

// Timer interrupt handler - called once per bit position.
ISR( TIMER2_COMP_vect )
{
	g_bitpos ++ ;
	g_bitpos &= 7;
	PORTD = g_timeslice[ g_bitpos ] ;
	// now set the delay...
	TCNT2 = 0;
	OCR2 <<= 1 ;
	if (g_bitpos == 0) OCR2 = 1 ; // reset the compare match value.
	if (g_bitpos == 7) g_tick = 1 ; // give the main loop a kick.
}
