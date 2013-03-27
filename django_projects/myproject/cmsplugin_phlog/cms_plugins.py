from django.utils.translation import ugettext as _

from cms.plugin_base import CMSPluginBase
from cms.plugin_pool import plugin_pool

from photologue.models import Photo

from cmsplugin_phlog.models import PhlogGalleryPlugin



class CMSPhlogPlugin(CMSPluginBase):
    model = PhlogGalleryPlugin
    name = _('Photologue Gallery')
    render_template = 'cms/plugins/phlog/gallery.html'
    
    def render(self, context, instance, placeholder):
        if instance.order == 'random':
            images = instance.gallery.sample(limit=instance.limit,
                                             public=instance.public)
        elif instance.order == 'date':
            images = instance.gallery.latest(limit=instance.limit,
                                             public=instance.public)
        else:
            images = instance.gallery.in_order(public=instance.public,
                                               limit=instance.limit)
        
        context.update({
            'gallery': instance.gallery,
            'image_list': images,
            'gallery_plugin': instance,
            'placeholder': placeholder})
        
        return context

plugin_pool.register_plugin(CMSPhlogPlugin)
