from django.contrib import admin
from cmsplugin_phlog.models import OrderedGallery, PhotoOrdering



class PhotoInline(admin.TabularInline):
    model = OrderedGallery.photos.through
    template = 'admin/photologue/orderedgallery/inline_photos.html'
    fields = ('order','photo',)
    ordering = ('order',)
    extra = 1

class OrderedGalleryAdmin(admin.ModelAdmin):
    list_display = ('title', 'date_added', 'photo_count', 'is_public')
    list_filter = ['date_added', 'is_public']
    date_hierarchy = 'date_added'
    prepopulated_fields = {'title_slug': ('title',)}
    filter_horizontal = ('photos',)
    inlines = [PhotoInline]

admin.site.register(OrderedGallery, OrderedGalleryAdmin)
