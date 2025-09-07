<template>
  <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      <div class="md:col-span-2">
        <FullCalendar
          ref="fullCalendar"
          :options="calendarOptions"
        />
      </div>
      <div class="hidden md:block col-span-1">
          <EventForm
              v-if="showForm"
              :eventData="selectedEvent"
              :groups="groups"
              @close="closeForm"
              @saved="handleEventSaved"
              @deleted="handleEventDeleted"
          />
      </div>

      <transition name="slide-up">
          <div
              v-if="showForm"
              class="fixed bottom-0 left-0 right-0 bg-white shadow-lg p-4 md:hidden rounded-t-2xl z-50"
          >
              <EventForm
              :eventData="selectedEvent"
              :groups="groups"
              @close="closeForm"
              @saved="handleEventSaved"
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
  props: {
    isLoggedIn: Boolean,
    currentUserId: String,
    currentUserName: String,
    groups: Array,
    initialEvents: Array
  },
  components: { FullCalendar, EventForm, EventDetail },
  data() {
    return {
      events: [],
      showForm: false,
      selectedEvent: null,
    };
  },
  computed: {
    isEdit() {
      return !!this.event
    },
    availableGroups() {
      return this.groups.length > 0 ? this.groups : this.groups
    },
    calendarOptions() {
      return {
        plugins: [dayGridPlugin, interactionPlugin],
        initialView: 'dayGridMonth',
        events: this.events,
        dateClick: this.handleDateClick,
        eventClick: this.handleEventClick,
        headerToolbar: {
          left: 'prev,next today',
          center: 'title',
          right: 'dayGridMonth'
        },
        height: 'auto',
        locale: 'ja',
        selectable: true, // 日付範囲選択を有効化
        selectMirror: true,
        select: this.handleDateRangeSelect, // 日付範囲選択ハンドラー
        unselectAuto: false
      };
    }
  },
  methods: {
    async fetchEvents() {
      try {
        const res = await axios.get("/events.json");
        this.events = res.data.map(event => ({
          id: event.id,
          title: event.title,
          start: event.start_time || event.start,
          end: event.end_time || event.end,
          description: event.description,
          group_id: event.group_id,
          extendedProps: {
            description: event.description,
            group_id: event.group_id,
            group: event.group
          }
        }));
        console.log('Fetched events:', this.events);
      } catch (error) {
        console.error('イベント取得エラー：', error);
      }
    },
    
    handleDateClick(info) {
      console.log('Date clicked:', info);
      
      // クリックした日付を適切な形式で設定
      const clickedDate = new Date(info.date);
      const startDateTime = new Date(clickedDate);
      startDateTime.setHours(9, 0, 0, 0); // デフォルトで9:00に設定
      
      const endDateTime = new Date(startDateTime);
      endDateTime.setHours(10, 0, 0, 0); // デフォルトで10:00に設定
      
      this.selectedEvent = { 
        start: startDateTime.toISOString(),
        end: endDateTime.toISOString(),
        title: '',
        description: ''
      };
      this.showForm = true;
    },
    
    // 日付範囲選択のハンドラーを追加
    handleDateRangeSelect(info) {
      console.log('Date range selected:', info);
      
      const startDateTime = new Date(info.start);
      const endDateTime = new Date(info.end);
      
      // 全日イベントでない場合の時刻設定
      if (info.allDay) {
        startDateTime.setHours(9, 0, 0, 0);
        endDateTime.setHours(10, 0, 0, 0);
      }
      
      this.selectedEvent = {
        start: startDateTime.toISOString(),
        end: endDateTime.toISOString(),
        title: '',
        description: ''
      };
      this.showForm = true;
    },
    
    handleEventClick(info) {
      console.log('Event clicked:', info);
      const eventId = info.event.id;
      this.showForm = true; 
      
      axios.get(`/events/${eventId}.json`)
      .then(res => {
        this.selectedEvent = {
          id: res.data.id,
          title: res.data.title,
          start: res.data.start_time || res.data.start,
          end: res.data.end_time || res.data.end,
          description: res.data.description,
          group_id: res.data.group_id,
          group: res.data.group
        };
        console.log('Selected event:', this.selectedEvent);
      })
      .catch(error => {
        console.error('イベント詳細取得エラー：', error);
        this.selectedEvent = null;
      });
    },
    
    openEditForm() {
      this.showForm = true;
    },

    closeForm() {
      this.showForm = false;
      this.selectedEvent = null;
      // カレンダーの選択状態をクリア
      if (this.$refs.fullCalendar) {
        this.$refs.fullCalendar.getApi().unselect();
      }
    },
    
    handleEventSaved() {
      this.fetchEvents();
      this.closeForm();
    },
    
    initializeEvents() {
      console.log('Initializing events...', this.initialEvents);
      if (this.initialEvents && Array.isArray(this.initialEvents)) {
        this.events = this.initialEvents.map(event => ({
          id: event.id,
          title: event.title,
          start: event.start_time || event.start,
          end: event.end_time || event.end,
          description: event.description,
          group_id: event.group_id,
          extendedProps: {
            description: event.description,
            group_id: event.group_id,
            group: event.group
          }
        }));
        console.log('Processed events:', this.events);
      } else {
        console.log('No initial events or not an array');
        this.events = [];
      }
    },
    handleEventDeleted() {
      this.fetchEvents();
      this.closeForm();
    }
  },
  
  mounted() {
    console.log('Calendar mounted');
    console.log('Initial events:', this.initialEvents);
    console.log('Props:', this.$props);
    
    this.initializeEvents();
    this.fetchEvents();
  },
};
</script>

<style>
.slide-up-enter-active,
.slide-up-leave-active {
  transition: transform 0.3s ease;
}

.slide-up-enter-from,
.slide-up-leave-to {
  transform: translateY(100%);
}
</style>