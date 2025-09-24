#include <stdint.h>

// BASE PERIFÉRICOS
#define PERIPHERAL_BASE_ADDRESS     0x40000000U
#define AHB_BASE_ADDRESS            (PERIPHERAL_BASE_ADDRESS + 0x00020000U)
#define RCC_BASE_ADDRESS            (AHB_BASE_ADDRESS + 0x00001000U)
#define IOPORT_ADDRESS              (PERIPHERAL_BASE_ADDRESS + 0x10000000U)

#define GPIOA_BASE_ADDRESS          (IOPORT_ADDRESS + 0x00000000U)
#define GPIOB_BASE_ADDRESS          (IOPORT_ADDRESS + 0x00000400U)
#define GPIOC_BASE_ADDRESS          (IOPORT_ADDRESS + 0x00000800U)

// ESTRUCTURAS
typedef struct{
    uint32_t MODER;
    uint32_t OTYPER;
    uint32_t OSPEEDR;
    uint32_t PUPDR;
    uint32_t IDR;
    uint32_t ODR;
    uint32_t BSRR;
    uint32_t LCKR;
    uint32_t AFR[2];
    uint32_t BRR;
} GPIOx_Reg_Def;

typedef struct{
    uint32_t CR;
    uint32_t ICSCR;
    uint32_t CRRCR;
    uint32_t CFGR;
    uint32_t CIER;
    uint32_t CIFR;
    uint32_t CICR;
    uint32_t IOPRSTR;
    uint32_t AHBPRSTR;
    uint32_t APB1PRSTR;
    uint32_t APB2PRSTR;
    uint32_t IOPENR;
    uint32_t AHBENR;
    uint32_t APBENR[2];
    uint32_t IOPSMENR;
    uint32_t AHBSMENR;
    uint32_t APBSMENR[2];
    uint32_t CCIPR;
    uint32_t CSR;
} RCC_Reg_Def;

 // Punteros, asignacion de memoria

#define GPIOA   ((GPIOx_Reg_Def*)GPIOA_BASE_ADDRESS)
#define GPIOB   ((GPIOx_Reg_Def*)GPIOB_BASE_ADDRESS)
#define GPIOC   ((GPIOx_Reg_Def*)GPIOC_BASE_ADDRESS)
#define RCC     ((RCC_Reg_Def*)RCC_BASE_ADDRESS)

// CONTROL DISPLAYS

#define D0_CTRL   (1U<<5)    // unidades minutos
#define D1_CTRL   (1U<<6)    // decenas minutos
#define D2_CTRL   (1U<<8)    // unidades horas
#define D3_CTRL   (1U<<9)    // decenas horas
#define ALL_DISPLAYS    (D0_CTRL|D1_CTRL|D2_CTRL|D3_CTRL)

//  MAPA 7-SEG

const uint8_t digit_map[10] = {
    0b00111111, // 0
    0b00000110, // 1
    0b01011011, // 2
    0b01001111, // 3
    0b01100110, // 4
    0b01101101, // 5
    0b01111101, // 6
    0b00000111, // 7
    0b01111111, // 8
    0b01101111  // 9
};

// VARIABLES
uint8_t hours24 = 0;     //  ponemos hora en 24h
uint8_t minutes = 0;
uint8_t display_digits[4] = {0,0,0,0}; // D0 al D3
uint8_t my_fsm = 0;      // multiplex
uint8_t mode_24h = 0;    // 0=12h, 1=24h

// Config de alarma

#define ALARM_HOUR      6
#define ALARM_MINUTE    0
#define ALARM_SECONDS   5
#define LOOPS_PER_SEC   200

static uint8_t alarm_active = 0;
static uint32_t alarm_loop_count = 0;

//  DELAY
void delay_ms(uint16_t n){
    for(; n>0; n--)
        for(volatile uint16_t i=0; i<140; i++);
}

// Refresh de los displays

void refresh_display_digits_from_time(void){
    uint8_t disp_hours;
    if(mode_24h){                 // si modo 24h
        disp_hours = hours24;
    } else {                      // convertir a 12h
        uint8_t h12 = hours24 % 12;
        if(h12 == 0) h12 = 12;
        disp_hours = h12;
    }

    display_digits[0] = minutes % 10;     // D0: unidades min
    display_digits[1] = minutes / 10;     // D1: decenas min
    display_digits[2] = disp_hours % 10;  // D2: unidades hr
    display_digits[3] = disp_hours / 10;  // D3: decenas hr
}

//Multi display
void update_display(void){
    uint8_t seg;

    switch(my_fsm){
        case 0: // D0 min unidades
            GPIOC->BSRR = (ALL_DISPLAYS << 16);
            GPIOB->BSRR = (0xFFU << 16);
            GPIOC->BSRR = D0_CTRL;
            GPIOB->BSRR = digit_map[ display_digits[0] ];
            my_fsm++;
            break;

        case 1: // D1 min decenas
            GPIOC->BSRR = (ALL_DISPLAYS << 16);
            GPIOB->BSRR = (0xFFU << 16);
            GPIOC->BSRR = D1_CTRL;
            GPIOB->BSRR = digit_map[ display_digits[1] ];
            my_fsm++;
            break;

        case 2: // D2 horas unidades
            GPIOC->BSRR = (ALL_DISPLAYS << 16);
            GPIOB->BSRR = (0xFFU << 16);
            GPIOC->BSRR = D2_CTRL;
            seg = digit_map[ display_digits[2] ] | 0x80; // DP ON mi separado de minutos
            GPIOB->BSRR = seg;
            my_fsm++;
            break;

        case 3: // D3 horas decenas
            GPIOC->BSRR = (ALL_DISPLAYS << 16);
            GPIOB->BSRR = (0xFFU << 16);
            GPIOC->BSRR = D3_CTRL;
            GPIOB->BSRR = digit_map[ display_digits[3] ];
            my_fsm = 0;
            break;
    }
}

//Funcion de boton de cambiar formato
void check_button(void){
    static uint8_t last_state = 1; // pull-up
    uint8_t state = (GPIOC->IDR & (1U<<13)) ? 1 : 0;

    if(last_state == 1 && state == 0){ // flanco
        delay_ms(40);
        if((GPIOC->IDR & (1U<<13)) == 0){
            mode_24h ^= 1;                 // cambiamos el modo
            refresh_display_digits_from_time();
            while((GPIOC->IDR & (1U<<13)) == 0) delay_ms(10);
        }
    }
    last_state = state;
}

// Led de alarma
void check_alarm_led(void){
    if(!alarm_active && hours24 == ALARM_HOUR && minutes == ALARM_MINUTE){
        alarm_active = 1;
        alarm_loop_count = ALARM_SECONDS * LOOPS_PER_SEC;
        GPIOA->ODR |= (1U << 5);  // LED ON
    }

    if(alarm_active){
        if(alarm_loop_count > 0){
            alarm_loop_count--;
        } else {
            alarm_active = 0;
            GPIOA->ODR &= ~(1U << 5); // LED OFF
        }
    }
}

//Actualizar el clock
void update_clock(void){
    minutes++;
    if(minutes >= 60){
        minutes = 0;
        hours24++;
        if(hours24 >= 24) hours24 = 0;
    }
    refresh_display_digits_from_time();
}

// Init

void init_hw(void){
    RCC->IOPENR |= (1U<<0); // GPIOA
    RCC->IOPENR |= (1U<<1); // GPIOB
    RCC->IOPENR |= (1U<<2); // GPIOC

    GPIOA->MODER &= ~(3U << (5*2));
    GPIOA->MODER |=  (1U << (5*2));   // PA5 salida LED

    GPIOB->MODER &= ~0xFFFFU;
    GPIOB->MODER |=  0x5555U;        // PB0 al PB7 salida segmentos

    GPIOC->MODER &= ~((3U<<10)|(3U<<12)|(3U<<16)|(3U<<18));
    GPIOC->MODER |=  ((1U<<10)|(1U<<12)|(1U<<16)|(1U<<18)); // PC5,6,8,9 displays

    GPIOC->MODER &= ~(3U << (13*2)); // PC13 input del boton

    GPIOC->BSRR = (ALL_DISPLAYS << 16);
    GPIOB->BSRR = (0xFFU << 16);
}

// ===================== MAIN =====================
int main(void){
    init_hw();

    hours24 = 0;
    minutes = 0;
    refresh_display_digits_from_time();

    uint16_t tick = 0;

    while(1){
        update_display();
        delay_ms(5);          // Aqui cambiamos la tasa de refresco

        tick++;
        if(tick >= 25){      // Velocidad
            tick = 0;
            update_clock();
        }

        check_alarm_led();
        check_button();       // nos permite cambiar 12/24h
    }
}
