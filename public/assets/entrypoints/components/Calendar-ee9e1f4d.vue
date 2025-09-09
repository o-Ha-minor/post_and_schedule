<template>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div class="md:col-span-2">
            <FullCalendar
            :plugins="[ dayGridPlugin, interactionPlugin ]"
            initialView="dayGridMonth"
            :events="events"
            @dateClick="handleDateClick"
            @eventClick="handleEventClick"
            />
        </div>
        <div class="hidden md:block col-span-1">
            <EventDetail
                v-if="selectedEvent && !showForm"
                :eventData="selectedEvent"
                @edit="openEditForm"
                @deleted="fetchEvents"
            />
            <EventForm
                v-if="selectedEvent && showForm"
                :eventData="selectedEvent"
                @close="closeForm"
                @saved="fetchEvents"
            />
        </div>

        <transition name="slide-up">
            <div
                v-if="showForm"
                class="fixed bottom-0 left-0 right-0 bg-white shadow-lg p-4 md:hidden rounded-t-2xl z-50"
            >
                <EventForm
                :eventData="selectedEvent"
                @close="closeForm"
                @saved="fetchEvents"
                />
            </div>
        </transition>
    </div>
  </template>
  
  <script>
  import FullCalendar from "@fullcalendar/vue3";
  import dayGridPlugin from "@fullcalendar/daygrid";
  import interactionPlugin from "@fullcalendar/interaction";
  import EventForm from "./EventForm.vue";
  import EventDetail from "./EventDetail.vue";
  import axios from "axios";
  
  export default {
    components: { FullCalendar, EventForm, EventDetail },
    data() {
      return {
        events: [],
        showForm: false,
        selectedEvent: null,
      };
    },
    methods: {
      async fetchEvents() {
        const res = await axios.get("/events.json");
        this.events = res.data;
      },
      async handleDateClick(info) {
        this.selectedEvent = { start: info.dateStr, end: info.dateStr };
        this.showForm = true;
      },
      async handleEventClick(info) {
        const res = await axios.get('/events/${info.event.id}.json')
        this.selectedEvent = res.data;
        this.showForm = false;
      },
      openEditForm() {
        this.showForm = true;
      },

      closeForm() {
        this.showForm = false;
      },
    },
    mounted() {
      this.fetchEvents();
    },
  };
  </script>

  <style>
  .slide-up-enter-form
  .slide-up-leave-to {
    transform: franslateY(100%);
  }
  </style>
  